From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] openvswitch: Fix dependency on IPv6 defrag.
Date: Fri, 11 Sep 2015 15:11:36 -0700
Message-ID: <CALnjE+qNBGWkLkTYP2cagp7gC2hFSc=ai7N48djADf3cqcezRw@mail.gmail.com>
References: <1442008876-19462-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442008876-19462-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 11, 2015 at 3:01 PM, Joe Stringer <joestringer@nicira.com> wrote:
> When NF_CONNTRACK is built-in, NF_DEFRAG_IPV6 is a module, and
> OPENVSWITCH is built-in, the following build error would occur:
>
> net/built-in.o: In function `ovs_ct_execute':
> (.text+0x10f587): undefined reference to `nf_ct_frag6_gather'
>
> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
> Reported-by: Jim Davis <jim.epost@gmail.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Looks good
Acked-by: Pravin B Shelar <pshelar@nicira.com>
