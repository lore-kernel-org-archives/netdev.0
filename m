From: "Magnus Damm" <magnus.damm@gmail.com>
Subject: Re: ax88796: add 93cx6 eeprom support
Date: Fri, 28 Sep 2007 17:29:59 +0900
Message-ID: <aec7e5c30709280129q158ad47y1b6cf9c8ea416993@mail.gmail.com>
References: <20070927105119.6515.35298.sendpatchset@clockwork.opensource.se>
	 <20070927150447.a9af14c5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lethal@linux-sh.org, jgarzik@pobox.com,
	ben-linux@fluff.org, "Francois Romieu" <romieu@fr.zoreil.com>
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:45059 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754788AbXI1IaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 04:30:00 -0400
Received: by py-out-1112.google.com with SMTP id u77so5080593pyb
        for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 01:29:59 -0700 (PDT)
In-Reply-To: <20070927150447.a9af14c5.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Thanks for picking up the patch.

On 9/28/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Thu, 27 Sep 2007 19:51:19 +0900
> Magnus Damm <magnus.damm@gmail.com> wrote:
>
> > ax88796: add 93cx6 eeprom support
> >
> > This patch hooks up the 93cx6 eeprom code to the ax88796 driver and modifies
> > the ax88796 driver to read out the mac address from the eeprom. We need
> > this for the ax88796 on certain SuperH boards. The pin configuration used
> > to connect the eeprom to the ax88796 on these boards is the same as pointed
> > out by the ax88796 datasheet, so we can probably reuse this code for multiple
> > platforms in the future.
>
> I'm showing a minor reject between this and Francois's git-r8169.patch.

[snip]
Oh, sorry about that. I should have built the patch on top of -mm instead.

> You both made the same change to eeprom_93cx6.h.  That all sounds good but
> it would be comforting if you could review each other's work, please...

I thought I was more or less the only user, but thanks for pointing that out.

The eeprom code in the r8169 driver from
2.6.23-rc8-mm2/git-r8169.patch looks fine, but I don't understand the
point of adding the size member to the eeprom struct in
eeprom_93cx6.h. Especially since no code change is made in
eeprom_93cx6.c.

Thanks,

/ magnus
