From: Sridhar Samudrala <samudrala@mail.com>
Subject: Re: some queries
Date: Mon, 17 Jun 2002 16:21:03 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <3D0E6EDF.9010207@mail.com>
References: <Pine.LNX.4.33L2.0206151420410.4436-100000@radical.corewars.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Ankit Jain <radical@corewars.org>
List-Id: netdev.vger.kernel.org

Ankit Jain wrote:

>Hi,
>
>I have been trying to find answers to some queries but noone seems to be
>able to help. My queries are: (kernel 2.4.18)
>
>1. what is tcp_ehash_bucket used for? hash table for tcp sockets? what
>does the "e" is the ehash mean/represent?
>
It is a hash table of all tcp sockets in ESTABLISHED state.

>
>2. Why is a tcp control socket created at init time in tcp_v4_init(..) ?
>Its of SOCK_RAW type and its unhashed to make sure that it doesnt receive
>any incoming packets. why? is it used to set some options or something?
>Where is it used?
>
The main purpose of this socket is to send RSTs when a packet is 
received for a non-existing socket.

Thanks
Sridhar

>
>Hoping for a reply!! :)
>
>-Ankit
>
>
>
>  
>
