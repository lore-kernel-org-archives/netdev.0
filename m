From: "Or Gerlitz" <or.gerlitz@gmail.com>
Subject: Re: [RFC] [PATCH 3/3] enable IP multicast when bonding IPoIB devices
Date: Wed, 27 Sep 2006 22:16:13 +0200
Message-ID: <15ddcffd0609271316r6e1ffea3ide84e87b66f3ad79@mail.gmail.com>
References: <Pine.LNX.4.64.0609261309540.24189@zuben>
	 <Pine.LNX.4.64.0609261317460.24189@zuben>
	 <20060926100535.7cde2de2@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Or Gerlitz" <ogerlitz@voltaire.com>, netdev@vger.kernel.org,
	"Roland Dreier" <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:25236 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1030751AbWI0UQO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 16:16:14 -0400
Received: by py-out-1112.google.com with SMTP id n25so422002pyg
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2006 13:16:13 -0700 (PDT)
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20060926100535.7cde2de2@freekitty>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/26/06, Stephen Hemminger <shemminger@osdl.org> wrote:
> On Tue, 26 Sep 2006 13:18:09 +0300 (IDT)
> Or Gerlitz <ogerlitz@voltaire.com> wrote:

> > +module_param(bonding_dev_type,    int, 0644);
> > +module_param(bonding_dev_addrlen, int, 0644);

> Do you really want to allow changing these values after module load?
> If not replace 0644 with 0

Nope, they are ment to be used only at load time, thanks for the
comment. Howeve, as i mentioned this patch is temporal workaround to
allow for have IP multicast supported when bondiong non ARPHRD_ETHER
devices. I am seeking better ways to do that.

Or.
