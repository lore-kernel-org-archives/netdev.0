From: Andi Kleen <ak@suse.de>
Subject: Re: System crash in tcp_fragment()
Date: Tue, 21 May 2002 11:49:22 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020521114922.B6519@wotan.suse.de>
References: <Pine.LNX.4.33.0205201836160.9301-100000@w-nivedita2.des.beaverton.ibm.com> <3CE9E466.AC2358EE@mvista.com> <20020520.230021.29510217.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: george@mvista.com, niv@us.ibm.com, kuznet@ms2.inr.ac.ru, ak@suse.de,
   netdev@oss.sgi.com, linux-net@vger.kernel.org, ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20020520.230021.29510217.davem@redhat.com>
List-Id: netdev.vger.kernel.org

> That's not the problem.  We use per-cpu values for each counter (and
> when the user asks for the value, we add together the values from
> each processor).

At least on x86 gcc usually seems to just generate an incl, which should
be ok because it is atomic enough (even when a reschedule happens it will 
act as a full memory barrier)

So it'll likely just be a problem for load-store architectures.


-Andi
