From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [RFD][PATCH] typhoon and core sample for folding away VLAN stuff
Date: Thu, 13 Apr 2006 11:38:59 +0300
Message-ID: <200604131138.59611.vda@ilport.com.ua>
References: <200604071628.30486.vda@ilport.com.ua> <200604122132.46113.ioe-lkml@rameria.de> <443DA830.8030209@thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: Ingo Oeser <ioe-lkml@rameria.de>, Ingo Oeser <netdev@axxeo.de>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 167.imtp.Ilyichevsk.Odessa.UA ([195.66.192.167]:35554 "HELO
	ilport.com.ua") by vger.kernel.org with SMTP id S964824AbWDMIj1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 04:39:27 -0400
To: Dave Dillow <dave@thedillows.org>
In-Reply-To: <443DA830.8030209@thedillows.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 13 April 2006 04:24, Dave Dillow wrote:
> Regardless, I remain opposed to this particular instance of bloat 
> busting. While both patches have improved in style, they remove a useful 
> feature and make the code less clean, for no net gain.

What happened to non-modular build? "no net gain" is not true.
 
> > This kind of changes are important, because bloat creeps in byte by byte
> > of unused features. So I really appreciate your work here Denis.
> 
> On SMP FC4, typhoon.ko has a text size of 68330, so you need to cut 2794 
> bytes to see an actual difference in memory usage for a module. Non-SMP 
> it is 67741, so there you only need to cut 2205 bytes to get a win.

This is silly. Should I go this route and try a dozen of different gcc
versions and "-O2 versus -Os" things to demonstrate that sometimes
it will matter?
--
vda
