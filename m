From: "David S. Miller" <davem@redhat.com>
Subject: Re: anyone ever done multicast AF_UNIX sockets?
Date: Mon, 03 Mar 2003 09:56:41 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030303.095641.87696857.davem@redhat.com>
References: <3E638C51.2000904@nortelnetworks.com>
	<20030303.085504.105424448.davem@redhat.com>
	<3E6399F1.10303@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: terje.eggestad@scali.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: cfriesen@nortelnetworks.com
In-Reply-To: <3E6399F1.10303@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Chris Friesen <cfriesen@nortelnetworks.com>
   Date: Mon, 03 Mar 2003 13:07:45 -0500
   
   Suppose I have a process that waits on UDP packets, the unified local 
   IPC that we're discussing, other unix sockets, and stdin.  It's awfully 
   nice if the local IPC can be handled using the same select/poll 
   mechanism as all the other messaging.

So use UDP, you still haven't backed up your performance
claims.  Experiment, set the SO_NO_CHECK socket option to
"1" and see if that makes a difference performance wise
for local clients.

But if performance is "so important", then you shouldn't really be
shying away from the shared memory suggestion and nothing is going to
top that (it eliminates all the copies, using flat out AF_UNIX over
UDP only truly eliminates some header processing, nothing more, the
copies are still there with AF_UNIX).
