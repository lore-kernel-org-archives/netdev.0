From: "Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>
Subject: RE: [PATCH 2.6.20 1/5] s2io: Making LRO and UFO as module loadable parameter.
Date: Mon, 29 Jan 2007 01:05:31 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD770125FFD8@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Leonid Grossman" <Leonid.Grossman@neterion.com>,
	"Ananda Raju" <Ananda.Raju@neterion.com>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>,
	"Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>,
	"Rastapur Santosh" <santosh.rastapur@neterion.com>,
	"Sriram Rapuru" <Sriram.Rapuru@neterion.com>
To: <netdev@vger.kernel.org>, "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [72.1.205.142] ([72.1.205.142]:46168 "EHLO owa.neterion.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S933160AbXA2GF3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jan 2007 01:05:29 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
Hi Jeff,

As per your comment I have synced up the patch with the latest
netdev-2.6.git#upstream branch. Also I have corrected the white space
issue. I have resubmitted the patches again.

Thanks,
~Siva
-----Original Message-----
From: Jeff Garzik [mailto:jeff@garzik.org]
Sent: Wednesday, January 24, 2007 2:56 AM
To: Ananda Raju
Cc: nBetdev@vger.kernel.org; Leonid Grossman; Alicia Pena; Ramkrishna
Vepa; Sreenivasa Honnur; Sriram Rapuru
Subject: Re: [PATCH 2.6.20 1/5] s2io: Making LRO and UFO as module
loadable parameter.

Ananda Raju wrote:
> This patch adds two load parameters napi and ufo. Previously NAPI was 
> compilation option with these changes wan enable disable NAPI using 
> load parameter. Also we are introducing ufo load parameter to 
> enable/disable ufo feature
> 
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>

ACK patches 1-5, but patch does not apply to netdev-2.6.git#upstream. 
Also, git-am complains about whitespace.


[jgarzik@pretzel netdev-2.6]$ git-am --signoff --utf8 /g/tmp/mbox

Applying 's2io: Making LRO and UFO as module loadable parameter.'

Space in indent is followed by a tab.
.dotest/patch:41:                       (block_no * 
(rxd_count[nic->rxd_mode] + 1)) + off;
Adds trailing whitespace.
.dotest/patch:46:               }
Space in indent is followed by a tab.
.dotest/patch:137:              * Rx handler is called by default, 
without checking for the
Space in indent is followed by a tab.
.dotest/patch:138:              * cause of interrupt.
Space in indent is followed by a tab.
.dotest/patch:139:              * rx_traffic_int reg is an R1 register, 
writing all 1's
error: patch failed: drivers/net/s2io.c:6985
error: drivers/net/s2io.c: patch does not apply Patch failed at 0001.
When you have resolved this problem run "git-am --resolved".
If you would prefer to skip this patch, instead run "git-am --skip".
