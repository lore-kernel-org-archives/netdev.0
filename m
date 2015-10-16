From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Fri, 16 Oct 2015 19:37:42 +0200
Message-ID: <20151016173742.GB9714@pox.localdomain>
References: <cover.1444956943.git.daniel@iogearbox.net>
 <ab1fceb2d68876d89bb2ebb3d2b45486d3cf2388.1444956943.git.daniel@iogearbox.net>
 <1444991103.2861759.411876897.42C807BD@webmail.messagingengine.com>
 <56212366.4000307@plumgrid.com>
 <1445013831.2945152.412200185.4C763002@webmail.messagingengine.com>
 <56213494.9070504@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	viro@ZenIV.linux.org.uk, ebiederm@xmission.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56213494.9070504@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/15 at 10:32am, Alexei Starovoitov wrote:
> On 10/16/15 9:43 AM, Hannes Frederic Sowa wrote:
> >Oh, tracing does not allow daemons. Why? I can only imagine embedded
> >users, no?
> 
> yes and for networking: restartability and HA.
> cannot really do that with fuse/daemons.

Right, the smaller the footprint, the better.
