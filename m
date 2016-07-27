From: alexmcwhirter@triadic.us
Subject: Re: PROBLEM: network data corruption (bisected to e5a4b0bb803b)
Date: Wed, 27 Jul 2016 14:04:06 -0400
Message-ID: <4dbfebe8136bc963b5b51463d6887db4@triadic.us>
References: <201607271032.u6RAWPcS008174@sdf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Christian Lamparter <chunkeey@googlemail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alan Curry <rlwinm@sdf.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201607271032.u6RAWPcS008174@sdf.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just to add some more information to this, the corruption seems to 
effect ssh as well.

Using a sun hme interface, occasionally upon an ssh connection it will 
refuse to authenticate a client with either password or cert 
authentication. Using wireshark to capture and decrypt the packets 
between the two machines, the data coming from the server seems good, 
but the data received by the server from the client is essentially 
garbage. Note that the client is sending valid data, but the server is 
corrupting it upon receipt. Closing the connection and starting a new 
one will remedy the login issue, but you do occasionally see corruption 
on the server side sporadically.

So far this only seems to occur on incoming data, outgoing data seems 
fine.
