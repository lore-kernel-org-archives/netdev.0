From: "David S. Miller" <davem@redhat.com>
Subject: Re: ip addr flush hangs
Date: Tue, 9 Mar 2004 16:06:30 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040309160630.37873bdd.davem@redhat.com>
References: <20040309152932.36a42997.davem@redhat.com>
	<OF34091B26.07758A8E-ON87256E52.00833C04-88256E53.00004022@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netdev-bounce@oss.sgi.com, okir@suse.de
Return-path: <netdev-bounce@oss.sgi.com>
To: Shirley Ma <xma@us.ibm.com>
In-Reply-To: <OF34091B26.07758A8E-ON87256E52.00833C04-88256E53.00004022@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 9 Mar 2004 15:56:00 -0800
Shirley Ma <xma@us.ibm.com> wrote:

> This fix causes a problem for SNMP IPv6 MIBs. It requires to dump all
> interface
> address types unicast/mcast/anycast. I would like suggest to fix the ip
> command to fix the problem.

We changed behavior which unexpectedly broke a pretty core tool
on everyone's system.  I'm not reverting this.

Create instead a new rtnetlink command which can ask for xxx_cast
type addresses on an interface.
