From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH RFC iproute2] Add VF link state control
Date: Wed, 08 May 2013 11:24:46 -0500
Message-ID: <1368030286.1664.16.camel@dcbw.foobar.com>
References: <1368020717-22194-1-git-send-email-ogerlitz@mellanox.com>
	 <1368020717-22194-4-git-send-email-ogerlitz@mellanox.com>
	 <20130508091753.0be79e6c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org,
	amirv@mellanox.com, ronye@mellanox.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45467 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756129Ab3EHQYp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 May 2013 12:24:45 -0400
In-Reply-To: <20130508091753.0be79e6c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-08 at 09:17 -0700, Stephen Hemminger wrote:
> On Wed,  8 May 2013 16:45:17 +0300
> Or Gerlitz <ogerlitz@mellanox.com> wrote:
> 
> > From: Rony Efraim <ronye@mellanox.com>
> > 
> > Add link state per VF command
> > 
> > Signed-off-by: Rony Efraim <ronye@mellanox.com>
> 
> Isn't this redundant with OPERSTATE and LOWER_DOWN?

I was going to say it was mostly redundant with the "set carrier from
userspace" patches from jpirko last December, but since a VF doesn't
appear to always have a netdev, it seems that functionality has to be
special-cased for VFs instead of being generic :(

Dan
