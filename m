From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFT] r8169 changes against 2.6.23-rc3
Date: Mon, 20 Aug 2007 14:58:05 -0400
Message-ID: <46C9E43D.4050306@oracle.com>
References: <20070818100701.GA20703@electric-eye.fr.zoreil.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000201040705080705090702"
Cc: netdev ML <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:40858 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752849AbXHTS7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 14:59:20 -0400
In-Reply-To: <20070818100701.GA20703@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000201040705080705090702
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Francois Romieu wrote:
> The latest serie of r8169 changes is available against 2.6.23-rc3 as:
> http://www.fr.zoreil.com/people/francois/misc/20070818-2.6.23-rc3-r8169-test.patch 
> 
> or (tarball sits one level higher):
> 
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.23-rc3/r8169-20070818/
> 
> or (rebase prone branch)
> 
> git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git#r8169
>  
> Please do not clone your whole git kernel tree from here, thanks.
> 
> Changes (most recent first):
> 
> - eeprom read support
> - phy init cleanup
> - PHY init for the 8168
> - make room for more PHY init changes
> - remove dead wood
> - add MAC identifiers
> - MSI support
> - correct phy parameters for the 8110SC
> 
> The first patch of the serie ("correct phy parameters for the 8110SC") has
> been elaborated with Edward Hsu from Realtek and it should help some owners
> of 8169 chipsets. If there is no report of regression for it on any
> chispet and it is reported to fix someone's problems, I will send it to
> Jeff Garzik for inclusion in 2.6.23 as a bugfix.
> 
> Anything else in this serie has not been tested on a wide scale nor acked
> by the manufacturer: I consider it post 2.6.23 material. That being said,
> the MSI changes seem fine and the "PHY init for the 8168" patch could make
> a difference for the users of the 8168 whose link is not properly
> negotiated.
> 
> Success and failure reports or patches will be welcome. Please Cc: netdev
> and include "r8169" in the Subject.

Tested 2.6.23-rc3 plus your patch on my dual-R8169 mini-ITX Jetway 
J7F4K1G2E mainboard.  No problems to report.

--------------000201040705080705090702
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------000201040705080705090702--
