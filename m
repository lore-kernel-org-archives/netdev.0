From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next PATCH v1 1/3] net: sched: af_packet support for
 direct ring access
Date: Tue, 7 Oct 2014 15:59:35 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174C621F@AcuExch.aculab.com>
References: <20141006000629.32055.2295.stgit@nitbit.x32>
	<CA+FuTSfwTBtZLu7CXh4bPxUtVubOvpCPo+O38BsnSiLdvV_KEA@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D174C5C35@AcuExch.aculab.com>
 <20141007.114341.1417644866461362364.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "willemb@google.com" <willemb@google.com>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"fw@strlen.de" <fw@strlen.de>,
	"gerlitz.or@gmail.com" <gerlitz.or@gmail.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"john.ronciak@intel.com" <john.ronciak@intel.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"danny.zhou@intel.com" <danny.zhou@intel.com>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:52500 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752028AbaJGQBI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 12:01:08 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 04465-08 for <netdev@vger.kernel.org>;
 Tue,  7 Oct 2014 17:01:03 +0100 (BST)
In-Reply-To: <20141007.114341.1417644866461362364.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David 
> From: David Laight <David.Laight@ACULAB.COM>
> Date: Tue, 7 Oct 2014 09:27:03 +0000
> 
> > That is (probably) the only scheme that stops the application
> > accessing random parts of physical memory.
> 
> I don't know where this claim keeps coming from, it's false.
> 
> The application has to attach memory to the ring, and then the
> ring can only refer to that memory for the duration of the
> session.
> 
> There is no way that the user can program the address field of the
> descriptors to point at arbitrary physical memory locations.
> 
> There is protection and control.

I got the impression that the application was directly writing the ring
structure that the ethernet mac hardware uses to describe tx and rx buffers.
(ie they are mapped read-write into userspace).
Unless you have a system where you can limit the physical memory
ranges accessible to the mac hardware, I don't see how you can stop
the application putting rogue values into the ring.

Clearly I'm missing something in my quick read of the change.

	David
