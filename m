From: "Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>
Subject: RE: [PATCH 2.6.20 1/5] s2io: Making LRO and UFO as module loadable parameter.
Date: Wed, 31 Jan 2007 14:13:10 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7701260789@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Leonid Grossman" <Leonid.Grossman@neterion.com>,
	"Alicia Pena" <Alicia.Pena@neterion.com>,
	"Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>,
	"Sriram Rapuru" <Sriram.Rapuru@neterion.com>,
	"Rastapur Santosh" <santosh.rastapur@neterion.com>
To: "Jeff Garzik" <jeff@garzik.org>,
	"Ananda Raju" <Ananda.Raju@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [72.1.205.142] ([72.1.205.142]:46157 "EHLO owa.neterion.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1030509AbXAaTNV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 14:13:21 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

Synced up the patches to the latest code from netdev#upstream branch and
also taken care of the Whitespaces. I have resubmitted all the five
patches again. Please apply it.

Thanks,
~Siva 

-----Original Message-----
From: Jeff Garzik [mailto:jeff@garzik.org] 
Sent: Wednesday, January 31, 2007 3:48 PM
To: Ananda Raju
Cc: netdev@vger.kernel.org; Leonid Grossman; Alicia Pena; Ramkrishna
Vepa; Sreenivasa Honnur; Sriram Rapuru; Sivakumar Subramani; Rastapur
Santosh
Subject: Re: [PATCH 2.6.20 1/5] s2io: Making LRO and UFO as module
loadable parameter.

Ananda Raju wrote:
> This patch adds two load parameters napi and ufo. Previously NAPI was 
> compilation option with these changes wan enable disable NAPI using 
> load parameter. Also we are introducing ufo load parameter to 
> enable/disable ufo feature
> 
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>

ACK patches 1-5, but still problems:

1) does not apply to netdev#upstream

2) adds trailing whitespace


[jgarzik@pretzel netdev-2.6]$ git-am --signoff --utf8 /g/tmp/mbox

Applying 's2io: Making LRO and UFO as module loadable parameter.'

Adds trailing whitespace.
.dotest/patch:46:               }
Adds trailing whitespace.
.dotest/patch:209:
error: patch failed: drivers/net/s2io.c:6984
error: drivers/net/s2io.c: patch does not apply Patch failed at 0001.
When you have resolved this problem run "git-am --resolved".
If you would prefer to skip this patch, instead run "git-am --skip".
