From: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2005@gmx.net>
Subject: Re: ip address delete bug?
Date: Wed, 05 Oct 2005 00:58:19 +0200
Message-ID: <4343090B.5010803@gmx.net>
References: <200593200127124@mail.routehat.org> <4342D3F9.80705@gmx.net>
	<Pine.NEB.4.62.0510042118190.24353@ukato.freeshell.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lartc@mailman.ds9a.nl, netdev@vger.kernel.org
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: Alexey Toptygin <alexeyt@freeshell.org>
In-Reply-To: <Pine.NEB.4.62.0510042118190.24353@ukato.freeshell.org>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

Alexey Toptygin schrieb:
> On Tue, 4 Oct 2005, Carl-Daniel Hailfinger wrote:
> 
>> OK, I found out that this is documented behaviour, although the hint 
>> is not in the man page.
> 
> If it's not in the man page, then where is the below quote from?

ip-cref.tex.

>> "secondary --- this address is not used when selecting the default 
>> source address for outgoing packets. An IP address becomes secondary 
>> if another address within the same prefix (network) already exists. 
>> The first address within the prefix is primary and is the tag address 
>> for the group of all the secondary addresses. When the primary address 
>> is deleted all of the secondaries are purged too."
>>
>> That means there is no way to change the IP of an interface if the 
>> prefix and network size stay the same. Are there any plans to fix that?
> 
> What's wrong with delete followed by add?

You are logged into the machine via ssh on eth0. You delete the ip 
address of eth0. How are you going to add the new address to eth0 now 
that your connection is gone? Go to the server room and use the console?

Normally, I would add the new IP to eth0, start another ssh to the new 
IP, log out from the session to the old IP, remove the old IP from eth0 
and be done. If I want the server to be reachable under both IPs during 
a transition period, I can delay deletion of the old IP until later.

> This thread started on netdev, so I'm cc-ing that, in case someone 
> doesn't read both lists.

Didn't start there, but if netdev is interested, we can keep them in cc.


>             Alexey

Regards,
Carl-Daniel
