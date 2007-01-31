From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.20 1/5] s2io: Making LRO and UFO as module loadable
 parameter.
Date: Wed, 31 Jan 2007 05:17:57 -0500
Message-ID: <45C06CD5.5030809@garzik.org>
References: <Pine.GSO.4.10.10701290043110.27317-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leonid.grossman@neterion.com,
	alicia.pena@neterion.com, ramkrishna.vepa@neterion.com,
	sreenivasa.honnur@neterion.com, sriram.rapuru@neterion.com,
	sivakumar.subramani@neterion.com, santosh.rastapur@neterion.com
To: Ananda Raju <Ananda.Raju@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55466 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932939AbXAaKSA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 05:18:00 -0500
In-Reply-To: <Pine.GSO.4.10.10701290043110.27317-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ananda Raju wrote:
> This patch adds two load parameters napi and ufo. Previously NAPI was
> compilation option with these changes wan enable disable NAPI using load
> parameter. Also we are introducing ufo load parameter to enable/disable
> ufo feature
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
error: drivers/net/s2io.c: patch does not apply
Patch failed at 0001.
When you have resolved this problem run "git-am --resolved".
If you would prefer to skip this patch, instead run "git-am --skip".
