From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tcp timestamp issues with google servers
Date: Tue, 22 May 2012 09:58:51 -0700
Message-ID: <4FBBC5CB.20201@hp.com>
References: <87r4ujno34.fsf@tucsk.pomaz.szeredi.hu> <1337278363.3403.39.camel@edumazet-glaptop> <87zk90s0em.fsf@tucsk.pomaz.szeredi.hu> <1337701259.3361.208.camel@edumazet-glaptop> <87mx50rz34.fsf@tucsk.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87mx50rz34.fsf@tucsk.pomaz.szeredi.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/22/2012 08:54 AM, Miklos Szeredi wrote:
> Eric Dumazet<eric.dumazet@gmail.com>  writes:
>
>> On Tue, 2012-05-22 at 17:25 +0200, Miklos Szeredi wrote:
>>
>>> So it appears.  The IP address is certainly registered to Google.
>>
>> Good, but you could have a middlebox doing transparent proxying.
>>
>> The SYNACK could be send by this box.
>
> Okay.  Is there a way to find out whether there is a middlebox or not?

The source IP in the trace was a 192.168 IP - is it possible/desirable 
to reproduce the problem without the device doing NAT in the path?

What is your "public" IP address?  Given that, and the IP address to 
which you are connecting, it should be possible to validate the RTT you 
are seeing.  If the geographic/topological location of the destination 
Google IP address is far enough from your public source IP that would 
show whether  the RTT you are seeing is even physically possible and so 
could suggest there is a middlebox (other than your NAT), though it 
couldn't show there was not a middlebox.


rick jones
