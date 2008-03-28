From: Guennadi Liakhovetski <lg@denx.de>
Subject: Bug in cs89x0.c?
Date: Fri, 28 Mar 2008 16:09:06 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0803281603110.4646@axis700.grange>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:39799 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753355AbYC1PIx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 11:08:53 -0400
Received: from lyakh (helo=localhost)
	by axis700.grange with local-esmtp (Exim 4.63)
	(envelope-from <g.liakhovetski@gmx.de>)
	id 1JfGCY-00023T-I0
	for netdev@vger.kernel.org; Fri, 28 Mar 2008 16:09:06 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Do I understand it right, that this

705:		i = readreg(dev, PP_LineCTL);
706:		/* Preserve the setting of the HCB1 pin. */
707:		if ((i & (HCB1 | HCB1_ENBL)) ==  (HCB1 | HCB1_ENBL))
708:			lp->adapter_cnf |= A_CNF_DC_DC_POLARITY;

(line numbers may deviate slightly) is a bug? HCB1 and HCB1_ENBL bits are 
from the PP_SelfCTL and not from the PP_LineCTL register...

Thanks
Guennadi
---
Guennadi Liakhovetski, Ph.D.

DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: +49-8142-66989-0 Fax: +49-8142-66989-80  Email: office@denx.de
