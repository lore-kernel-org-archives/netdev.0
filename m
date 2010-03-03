From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Tue, 2 Mar 2010 16:07:43 -0800
Message-ID: <20100303000743.GA13744@us.ibm.com>
References: <4B88E431.6040609@parallels.com> <m1bpfbqajn.fsf@fess.ebiederm.org> <4B894564.7080104@parallels.com> <m1iq9io5sc.fsf@fess.ebiederm.org> <4B89727C.9040602@parallels.com> <m1ljeempk6.fsf@fess.ebiederm.org> <4B8AE8C1.1030305@free.fr> <4B8D28CF.8060304@parallels.com> <20100302211942.GA17816@us.ibm.com> <m1y6iaqsmm.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1y6iaqsmm.fsf@fess.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman [ebiederm@xmission.com] wrote:
| 
| I think replacing a struct pid for another struct pid allocated in
| descendant pid_namespace (but has all of the same struct upid values
| as the first struct pid) is a disastrous idea.  It destroys the

True. Sorry, I did not mean we would need a new 'struct pid' for an
existing process. I think we talked earlier of finding a way of attaching
additional pid numbers to the same struct pid.

Sukadev

