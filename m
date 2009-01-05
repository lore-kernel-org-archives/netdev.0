From: Speedster <speedster@haveacry.com>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
 2.6.27
Date: Mon, 05 Jan 2009 20:19:46 +0900
Message-ID: <4961ECD2.1000502@haveacry.com>
References: <bug-12327-10286@http.bugzilla.kernel.org/> <20081229214101.4c4f5ac1.akpm@linux-foundation.org> <Pine.LNX.4.64.0812311241490.3120@wrl-59.cs.helsinki.fi> <495BFEAF.6000006@haveacry.com> <20090102083402.GA24383@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030509020705030707040309"
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosted06.westnet.com.au ([203.10.1.221]:55492 "EHLO
	hosted06.westnet.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138AbZAELTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 06:19:55 -0500
In-Reply-To: <20090102083402.GA24383@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030509020705030707040309
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> On Wed, Dec 31, 2008 at 11:22:23PM +0000, Speedster wrote:
>> The gateway machine (whinge) runs as a KVM guest, and shares a physical  
>> host with three other guests (one Windows, two Linux). Below are the  
>> outputs of bridge topology and VLAN tagging on the physical host.
> 
> What driver are you using on whinge?
> 
> When you took the packet dumps, was it on whinge or the physical
> host? If it was taken on whinge, can you try to take the same
> dumps on the outgoing physical interface on the host?
> 
> Thanks,

I have tried both virtio and the default (8139too). The original dumps 
were taken on whinge, I have attached two new dumps showing the 
functional (2.6.24) and non-functional (2.6.27) states from the host.

Cheers
Dean

--------------030509020705030707040309
Content-Type: application/octet-stream;
 name="whinge-2.6.27_whimper-dump.cap"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="whinge-2.6.27_whimper-dump.cap"

1MOyoQIABAAAAAAAAAAAAP//AAABAAAADuphSds/BQBSAAAAUgAAAAAYGFQZVAAWPiT3oYhk
EQAgZgA+ACFFEAA8zoVAAEAGUVvKSKLjEZWcCoX2AFD9lmjqAAAAAKACFrCDWAAAAgQFrAQC
CAr//6ZvAAAAAAEDAwQR6mFJpzQFAFIAAABSAAAAABgYVBlUABY+JPehiGQRACBmAD4AIUUQ
ADzOhkAAQAZRWspIouMRlZwKhfYAUP2WaOoAAAAAoAIWsIIsAAACBAWsBAIICv//p5sAAAAA
AQMDBBfqYUkTNQUAUgAAAFIAAAAAGBhUGVQAFj4k96GIZBEAIGYAPgAhRRAAPM6HQABABlFZ
ykii4xGVnAqF9gBQ/ZZo6gAAAACgAhawf9QAAAIEBawEAggK//+p8wAAAAABAwMEI+phSVI1
BQBSAAAAUgAAAAAYGFQZVAAWPiT3oYhkEQAgZgA+ACFFEAA8zohAAEAGUVjKSKLjEZWcCoX2
AFD9lmjqAAAAAKACFrB7JAAAAgQFrAQCCAr//66jAAAAAAEDAwQ76mFJLzYFAFIAAABSAAAA
ABgYVBlUABY+JPehiGQRACBmAD4AIUUQADzOiUAAQAZRV8pIouMRlZwKhfYAUP2WaOoAAAAA
oAIWsHHEAAACBAWsBAIICv//uAMAAAAAAQMDBA==
--------------030509020705030707040309
Content-Type: application/octet-stream;
 name="whinge-2.6.24_whimper-dump.cap"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="whinge-2.6.24_whimper-dump.cap"

1MOyoQIABAAAAAAAAAAAAP//AAABAAAA4OthSUnUCgBSAAAAUgAAAAAbDDwHJAAWPiT3oYhk
EQAWrwA+ACFFEAA8at5AAEAGtQLKSKLjEZWcCtqwAFCwJsuVAAAAAKACFrAehwAAAgQFrAQC
CAr//6FLAAAAAAEDAwTg62FJkr0OAD4AAAA+AAAAABsMPAckABY+JPehiGQRABavACoAIUUQ
AChq30AAQAa1FcpIouMRlZwK2rAAULAmy5aga7QxUBAWsNL9AADn62FJHsgGAE8AAABPAAAA
ABsMPAckABY+JPehiGQRABavADsAIUUQADlq4EAAQAa1A8pIouMRlZwK2rAAULAmy5aga7Qx
UBgWsPgkAABIRUFEIC8gSFRUUC8xLjENCuvrYUl6ww0AVQAAAFUAAAAAGww8ByQAFj4k96GI
ZBEAFq8AQQAhRRAAP2rhQABABrT8ykii4xGVnArasABQsCbLp6BrtDFQGBawgywAAEhvc3Q6
IHN0b3JlLmFwcGxlLmNvbQ0K7OthSYjvAwBAAAAAQAAAAAAbDDwHJAAWPiT3oYhkEQAWrwAs
ACFFEAAqauJAAEAGtRDKSKLjEZWcCtqwAFCwJsu+oGu0MVAYFrDFwQAADQrs62FJA9YHAD4A
AAA+AAAAABsMPAckABY+JPehiGQRABavACoAIUUQAChq40AAQAa1EcpIouMRlZwK2rAAULAm
y8Cga7R1UBAWsNKPAADu62FJRNwJAD4AAAA+AAAAABsMPAckABY+JPehiGQRABavACoAIUUQ
AChq5EAAQAa1EMpIouMRlZwK2rAAULAmy8Cga7R1UBEWsNKOAADu62FJjL8NAD4AAAA+AAAA
ABsMPAckABY+JPehiGQRABavACoAIUUQAChq5UAAQAa1D8pIouMRlZwK2rAAULAmy8Gga7R2
UBAWsNKNAAA=
--------------030509020705030707040309--
