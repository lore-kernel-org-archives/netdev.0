From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 in netdev experimental
Date: Sun, 4 Jan 2004 23:38:49 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040104233849.A3214@electric-eye.fr.zoreil.com>
References: <20031122183001.GA16993@gtf.org> <20031124000939.A456@electric-eye.fr.zoreil.com> <20031126004550.A25408@electric-eye.fr.zoreil.com> <20031127235143.A16767@electric-eye.fr.zoreil.com> <20031130014738.A2589@electric-eye.fr.zoreil.com> <3FF846C3.5070207@mainstreetsoftworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>, brad_mssw@gentoo.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Brad House <brad@mainstreetsoftworks.com>
Content-Disposition: inline
In-Reply-To: <3FF846C3.5070207@mainstreetsoftworks.com>; from brad@mainstreetsoftworks.com on Sun, Jan 04, 2004 at 12:00:51PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Brad House <brad@mainstreetsoftworks.com> :
[...]
> Let me know where to start debugging this, as I should
> have some time here.

static u32 rtl8169_rx_fill(struct rtl8169_private *tp, struct net_device *dev,
                           u32 start, u32 end)
{
        u32 cur;
        
        for (cur = start; end - start > 0; cur++) {
                                ^^^^^
This should read:

        for (cur = start; end - cur > 0; cur++) {

Care to test 2.6.1-rc1-mm1 and simply change the offending line ?

--
Ueimor
