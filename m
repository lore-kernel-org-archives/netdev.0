From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH net-next V4 6/9] Altera TSE: Add main and header file for
 Altera Ethernet Driver
Date: Wed, 12 Mar 2014 19:45:47 -0500
Message-ID: <CAOwfj2NfovY=NdiDy3846WVV4Bw-jVPUMNmKY09M-i1014E16A@mail.gmail.com>
References: <1394655334-29547-1-git-send-email-vbridgers2013@gmail.com>
	<1394655334-29547-7-git-send-email-vbridgers2013@gmail.com>
	<1394656962.3915.41.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Landley <rob@landley.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:44331 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbaCMAps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 20:45:48 -0400
In-Reply-To: <1394656962.3915.41.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe,

On Wed, Mar 12, 2014 at 3:42 PM, Joe Perches <joe@perches.com> wrote:
> On Wed, 2014-03-12 at 15:15 -0500, Vince Bridgers wrote:
>> This patch adds the main driver and header file for the Altera Triple
>> Speed Ethernet driver.
> []
>> diff --git a/drivers/net/ethernet/altera/altera_tse.h b/drivers/net/ethernet/altera/altera_tse.h
> []
>> +/* MAC register Space. Note that some of these registers may or may not be
>> + * present depending upon options chosen by the user when the core was
>> + * configured and built. Please consult the Altera Triple Speed Ethernet User
>> + * Guide for details.
>> + */
>> +struct altera_tse_mac {
>> +     /* Bits 15:0: MegaCore function revision (0x0800). Bit 31:16: Customer
>> +      * specific revision
>> +      */
>> +     unsigned int megacore_revision;
>> +     /* Provides a memory location for user applications to test the device
>> +      * memory operation.
>> +      */
>> +     unsigned int scratch_pad;
>> +     /* The host processor uses this register to control and configure the
>> +      * MAC block
>> +      */
>> +     unsigned int command_config;
>> +     /* 32-bit primary MAC address word 0 bits 0 to 31 of the primary
>> +      * MAC address
>> +      */
>> +     unsigned int mac_addr_0;
>> +     /* 32-bit primary MAC address word 1 bits 32 to 47 of the primary
>> +      * MAC address
>> +      */
>
> maybe all of these should be specifically sized using u32 like
>
>         u32 mac_addr_0;
>
>

yes, I agree - that would be better. I'll pick this up in V5.

Cheers,

Vince
