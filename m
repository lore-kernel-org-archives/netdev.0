From: "Vladimir B. Savkin" <master@sectorb.msk.ru>
Subject: Re: [RFC/PATCH] IMQ port to 2.6
Date: Sun, 1 Feb 2004 00:58:21 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040131215821.GA3615@usr.lcm.msu.ru>
References: <20040126093230.GA17811@usr.lcm.msu.ru> <1075124312.1732.292.camel@jzny.localdomain> <20040126135545.GA19497@usr.lcm.msu.ru> <1075127396.1746.370.camel@jzny.localdomain> <20040131185231.GA2608@usr.lcm.msu.ru> <1075580812.1035.83.camel@jzny.localdomain> <20040131205326.GA3089@usr.lcm.msu.ru> <1075584318.1033.159.camel@jzny.localdomain> <20040131213236.GA3451@usr.lcm.msu.ru> <1075585764.1035.192.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1075585764.1035.192.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jan 31, 2004 at 04:49:24PM -0500, jamal wrote:
> Still a few rough edges, so bear with me:
> Would you not be able to achieve the same if you used the marking scheme
> i described earlier on eth0 and used HTB or HFSC or CBQ (as non-work
> conserving) on eth1/2? I was suggesting prio before and you pointed you
> the queues will never be full for that to have any value. 
> 

Well, not, the primary reason being that there would be no single class
with appropriate bandwith limit (ceil). There would be multiple classes,
one for each egress interface, and actual upper limit would be the sum
of bandwidths of every class. I would have to limit every class to
some part of the aggregate limit, and it would have been enforced, even if
other classes are not using their shares. So, no fairness.

~
:wq
                                        With best regards, 
                                           Vladimir Savkin. 
