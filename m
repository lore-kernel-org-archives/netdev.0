From: Steven King <sfking@fdwdc.com>
Subject: Re: [PATCH net-next] fec: Add support for Coldfire M5441x enet-mac.
Date: Wed, 6 Jun 2012 13:05:48 -0700
Message-ID: <201206061305.48893.sfking@fdwdc.com>
References: <201206061006.21288.sfking@fdwdc.com> <4FCF949D.7060402@computer.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	uClinux development list <uclinux-dev@uclinux.org>,
	Greg Ungerer <gerg@snapgear.com>
To: Jan Ceuleers <jan.ceuleers@computer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm27-vm0.access.bullet.mail.mud.yahoo.com ([66.94.236.227]:45039
	"HELO nm27-vm0.access.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757653Ab2FFUFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 16:05:50 -0400
In-Reply-To: <4FCF949D.7060402@computer.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 06 June 2012 10:34:21 am Jan Ceuleers wrote:
> On 06/06/2012 07:06 PM, Steven King wrote:
> > Add support for the Freescale Coldfire M5441x; as these parts have an
> > enet-mac, add a quirk to distinguish them from the other Coldfire parts
> > so we can use the existing enet-mac support.
>
> Stephen,
>
> You are activating certain functionality based on whether M5441x is
> defined. But where is this being defined? Should this not be added in a
> Kconfig somewhere as a platform option?

Yes.  Hopefully, once I send Greg my updated patches to add support for the 
m5441x, then it will be a selection in the m68k port.  I just happened to 
have these ready to go after David chastised me for sending them too late in 
the last merge cycle...
