From: Ethan Sommer <sommere@ethanet.com>
Subject: Re: [Fwd: [ANNOUNCE] Layer-7 Filter for Linux QoS]
Date: Thu, 22 May 2003 09:40:17 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3ECCE151.8000903@ethanet.com>
References: <Pine.LNX.4.40.0305221019240.29409-100000@phil.home.phil>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi <hadi@shell.cyberus.ca>,
	Martin Josefsson <gandalf@wlug.westbo.se>,
	"David S. Miller" <davem@redhat.com>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
In-reply-to: <Pine.LNX.4.40.0305221019240.29409-100000@phil.home.phil>
To: Philippe Biondi <biondi@cartel-securite.fr>
List-Id: netdev.vger.kernel.org

Philippe Biondi wrote:

>>I take it back, it is regular (kinda) but you can't to it with a
>>deterministic finite atomaton. If there is a cycle in pattern1, off of
>>which pattern2 has a branch, then you would need to count how many times
>>you have gone around the cycle to know where to jump to in pattern2 if
>>it fails to match pattern1 (which you can't do, pumping lemma and all
>>that.) If you use a non-determistic FA, you should be able to just go
>>through each pattern until both crash or one matches and declare that
>>the winner.
>>    
>>
>
>
>Strange way of reasoning... what if pattern1 is "(subpat1|subpat2)" ?
>regexp is a regular language so it is equivalent to a DFA.
>For every NDFA, there exist a DFA that recognize the same language.
>So, it is possible.
>

That is true only if you only care if either are matched. Not if you 
care which is matched. By combining them you lose the ability to tell 
which matched.

>
>The question is : will we have enough memory to store a DFA that recognize
>a big regexp ? The answer is : let loose some speed and use NDFA.
>  
>

you will have to for the reason above.




