From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.13] pcnet32: set min ring size to 4
Date: Wed, 14 Sep 2005 08:28:37 -0400
Message-ID: <43281775.2060207@pobox.com>
References: <4325298D.1010600@tw.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fubar@us.ibm.com, donf@us.ibm.com, jklewis@us.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965135AbVINM2o@vger.kernel.org>
To: Hubert WS Lin <wslin@tw.ibm.com>
In-Reply-To: <4325298D.1010600@tw.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hubert WS Lin wrote:
> Hi,
> 
> Don Fry reminded me that the pcnet32_loopback_test() asssumes the ring 
> size is no less than 4. The minimum ring size was changed to 4 in 
> pcnet32_set_ringparam() to allow the loopback test to work unchanged.
> 
> Changelog:
> - Set minimum ring size to 4 to allow loopback test to work unchanged
> - Moved variable init_block to first field in struct pcnet32_private
> 
> Signed-off-by: Hubert WS Lin <wslin@tw.ibm.com>

Patch OK, but:

Applying 'pcnet32: set min ring size to 4'

error: patch failed: drivers/net/pcnet32.c:22
error: drivers/net/pcnet32.c: patch does not apply


Please resend, without MIME attachments.

	Jeff
