From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH,TRIVIAL] Fix csum_ipv6_magic asm memory clobber
Date: Wed, 30 Sep 2009 16:45:33 -0700
Message-ID: <4AC3ED9D.6030701@zytor.com>
References: <4AC3DF7B.5060407@zytor.com>	<20090930230138.GZ6451@const.famille.thibault.fr>	<20090930161939.8c6d140a.akpm@linux-foundation.org> <20090930.162233.208543104.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, samuel.thibault@ens-lyon.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, tglx@linutronix.de,
	andi@firstfloor.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754964AbZI3Xqd@vger.kernel.org>
In-Reply-To: <20090930.162233.208543104.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/30/2009 04:22 PM, David Miller wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Wed, 30 Sep 2009 16:19:39 -0700
> 
>> From: Samuel Thibault <samuel.thibault@ens-lyon.org>
>>
>> Just like ip_fast_csum, the assembly snippet in csum_ipv6_magic needs a
>> memory clobber, as it is only passed the address of the buffer, not a
>> memory reference to the buffer itself.
>>
>> This caused failures in Hurd's pfinetv4 when we tried to compile it with
>> gcc-4.3 (bogus checksums).
>>
>> Signed-off-by: Samuel Thibault <samuel.thibault@ens-lyon.org>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> I'm happy to see this go in via the x86 tree, and thus:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

I'll put it in x86/urgent tonight or early tomorrow morning (just about
to leave for the airport.)

	-hpa
