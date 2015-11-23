From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Mon, 23 Nov 2015 13:44:50 +0100
Message-ID: <56530A42.6030609@profihost.ag>
References: <564B3D35.50004@profihost.ag>
 <alpine.DEB.2.11.1511171936030.3761@nanos> <564B7F9D.5060701@profihost.ag>
 <alpine.DEB.2.11.1511172041480.3761@nanos> <564CDE2F.8000201@profihost.ag>
 <564CEB0C.40006@redhat.com> <564CEF5D.3080005@profihost.ag>
 <564D9A17.6080305@redhat.com> <564D9B21.302@profihost.ag>
 <564D9CE6.2090104@profihost.ag>
 <1447933294.1974772.444210441.67F1AC5E@webmail.messagingengine.com>
 <564DB5F5.9060208@profihost.ag>
 <1447936902.1986892.444251921.3928A049@webmail.messagingengine.com>
 <564DC4A5.70104@profihost.ag> <564DCC4C.1090009@redhat.com>
 <564E2852.8000200@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Weimer <fweimer@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <564E2852.8000200@profihost.ag>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 19.11.2015 um 20:51 schrieb Stefan Priebe:
> 
> Am 19.11.2015 um 14:19 schrieb Florian Weimer:
>> On 11/19/2015 01:46 PM, Stefan Priebe - Profihost AG wrote:
>>
>>> I can try Kernel 4.4-rc1 next week. Or something else?
>>
>> I found this bug report which indicates that 4.1.10 works:
>>
>>    <https://issues.asterisk.org/jira/browse/ASTERISK-25251>
>>
>> But in your original report, you said that 4.1.13 is broken.
> 
> That's correct i'm running 4.1.13.
> 
>> This backtrace:
>>
>>    <https://issues.asterisk.org/jira/secure/attachment/52702/bt.txt>
>>
>> shows a lot of waiting on quite different netlink sockets.  So if this
>> is due to a race in Asterisk, it must have happened several times in a
>> row.

Kernel 4.4-rc2 works fine. How can we grab / get an idea which is
causing the isse in 4.1? It's an LTE kernel so it should be fixed!

Stefan
