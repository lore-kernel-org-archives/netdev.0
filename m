From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH net-next 04/11] openvswitch: Restructure
 datapath.c and flow.c
Date: Tue, 29 Oct 2013 18:32:35 -0700
Message-ID: <1383096755.12439.46.camel@joe-AO722>
References: <1383092544-50599-1-git-send-email-jesse@nicira.com>
	<1383092544-50599-5-git-send-email-jesse@nicira.com>
	<1383096313.12439.44.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1383096313.12439.44.camel@joe-AO722>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-10-29 at 18:25 -0700, Joe Perches wrote:
> On Tue, 2013-10-29 at 17:22 -0700, Jesse Gross wrote:
> > Over the time datapath.c and flow.c has became pretty large files.
> > Following patch restructures functionality of component into three
> > different components:
> []
> >  net/openvswitch/Makefile       |    2 +
> >  net/openvswitch/datapath.c     |  528 +------------
> >  net/openvswitch/datapath.h     |    1 +
> >  net/openvswitch/flow.c         | 1605 +---------------------------------------
> >  net/openvswitch/flow.h         |  128 +---
> >  net/openvswitch/flow_netlink.c | 1603 +++++++++++++++++++++++++++++++++++++++
> 
> Is this largish patch any different or easier to
> read/verify when generated with git format-patch -M ?

After a git pull, the short answer is no.
Oh well.
