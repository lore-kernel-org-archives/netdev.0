From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 04/26] rt2x00: EEPROM 93Cx6
Date: Sun, 3 Dec 2006 19:45:58 +0100
Message-ID: <200612031945.58543.IvDoorn@gmail.com>
References: <200612031919.05228.IvDoorn@gmail.com> <200612031339.28148.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:37812 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1759980AbWLCSqQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:46:16 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4149984nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:46:15 -0800 (PST)
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200612031339.28148.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 03 December 2006 19:39, Michael Wu wrote:
> On Sunday 03 December 2006 13:19, Ivo van Doorn wrote:
> > rt2400pci, rt2500pci and rt61pci share exactly the
> > same code for the eeprom reading. The only difference
> > is that rt61pci has a slightly different register reading
> > approach. In any case we have a lot of duplicate code.
> > Create a new module eeprom_93cx6 inside the rt2x00 folder
> > and make rt2x00 use that.
> Interesting. adm8211 has code to read 93C66 and 93C46 eeproms, and it looks 
> similar, albeit smaller and simpler, to your 93cx6 reading code. However, it 
> looks like your new eeprom reading code is general enough for adm8211 to use 
> too. I'll have to try it..

Good to hear, I'll check it out as well.
If they are indeed similar the eeprom_93cx6 could be moved to a more general
location as well so the module can be shared. :)

Ivo
