From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] openvswitch: Fix IPv6 exthdr handling with ct helpers.
Date: Mon, 14 Sep 2015 16:53:56 -0700
Message-ID: <CALnjE+oQJ03J7jwKxUyvJLqfHVOD7EQHAauBO8HbVFMte=8Spw@mail.gmail.com>
References: <1442254490-20385-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, dan.carpenter@oracle.com
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442254490-20385-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 14, 2015 at 11:14 AM, Joe Stringer <joestringer@nicira.com> wrote:
> Static code analysis reveals the following bug:
>
>         net/openvswitch/conntrack.c:281 ovs_ct_helper()
>         warn: unsigned 'protoff' is never less than zero.
>
> This signedness bug breaks error handling for IPv6 extension headers when
> using conntrack helpers. Fix the error by using a local signed variable.
>
> Fixes:  cae3a2627520: "openvswitch: Allow attaching helpers to ct
> action"
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Acked-by: Pravin B Shelar <pshelar@nicira.com>
