From: "David S. Miller" <davem@redhat.com>
Subject: Re: RFC/PATCH capture qdisc requeue event in stats
Date: Mon, 30 Aug 2004 14:40:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830144033.2265a6e6.davem@redhat.com>
References: <1093799632.1073.410.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1093799632.1073.410.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 29 Aug 2004 13:13:52 -0400
jamal <hadi@cyberus.ca> wrote:

> Opinions welcome - If all is good, Dave please apply.

tc_stats changes size, how will existing applications cope?
Since it is just RTA_PUT() into userspace, will that just work
or will existing apps bomb because they'll do a check of the
size field of the rtnetlink attribute?
