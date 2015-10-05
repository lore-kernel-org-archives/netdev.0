From: Steven Schlansker <stevenschlansker@gmail.com>
Subject: Re: Glibc recvmsg from kernel netlink socket hangs forever
Date: Mon, 5 Oct 2015 16:26:04 -0700
Message-ID: <368A90AB-8181-4C13-B5EA-B9378CA4C71B@gmail.com>
References: <C3C03EFC-53E1-45DE-87AF-59C7367BD21E@gmail.com> <20150925043653.GA29111@roeck-us.net> <20150925045853.GA5286@gondor.apana.org.au> <5604DCD2.4090600@roeck-us.net> <38FEC418-9C09-47BC-A9FC-5F1EA28941FC@gmail.com> <560609E3.4070307@roeck-us.net>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8BIT
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	netdev@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <560609E3.4070307@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sep 25, 2015, at 7:58 PM, Guenter Roeck <linux@roeck-us.net> wrote:

> On 09/25/2015 02:37 PM, Steven Schlansker wrote:
>> 
>> 
>> Thank you for the patches to try, I'll build a kernel with them early next week
>> and report back.  It sounds like it may not match my problem exactly so we'll
>> see.
>> 
> 
> For 4.0.x, you _really_ need to update to 4.0.9 to get the following two patches.
> 
> cf8befcc1a55 netlink: Disable insertions/removals during rehash
> 18889a4315a5 netlink: Reset portid after netlink_insert failure

Hi Guenter,

Thank you very much for the information.  We upgraded to 4.0.9 and all indications are that
the issue is gone.  I will follow up if that is not the case.

Thank you everyone for your guidance.
