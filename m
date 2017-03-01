From: Nikolay Aleksandrov via Bridge <bridge@lists.linux-foundation.org>
Subject: Re: [PATCH] net: bridge: allow IPv6 when multicast flood
	is disabled
Date: Wed, 1 Mar 2017 13:05:49 +0200
Message-ID: <c1d9bb98-9eda-e24f-d3b3-b324b326cad6@cumulusnetworks.com>
References: <1488215489-26372-1-git-send-email-mmanning@brocade.com>
	<E4A652DE-AC03-4E8D-B50E-8BE92DCA31C5@cumulusnetworks.com>
	<b6377d29-3dad-5671-8690-1fff04196723@brocade.com>
Reply-To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
To: Mike Manning <mmanning@brocade.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <b6377d29-3dad-5671-8690-1fff04196723@brocade.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 01/03/17 11:57, Mike Manning wrote:
> On 28/02/17 09:20, Nikolay Aleksandrov wrote:
>> We are aware of this and have discussed it, but I’m not sure this is the best way to fix it,
>> it will still allow local IPv4 mcast to be flooded on all ports even with that flag removed and
>> that definitely changes user-visible behaviour (even if it is okay) and will not be appropriate
>> for -net.
>>
>> Let me get back to you on this one.
>>
>> Thanks,
>>  Nik
>>
> Thanks for your comments, I have sent a v2 patch accordingly in case you have no better suggestion.
> We need per-port disabling of multicast flooding, but have to apply this patch to allow IPv6
> connectivity so as to make it usable. There is no noteworthy impact on IPv4 as the fix only allows
> packets originated by the device. As this feature is new to the 4.9 kernel, there are no backwards
> compatibility issues with prior kernel versions if this fix is also applied to the 4.9 kernel.
> 

Okay, I agree and have also discussed it with some colleagues so this seems like the right way
to go. I'll review the v2 in a minute.

Thank you,
 Nik
