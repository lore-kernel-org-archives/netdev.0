From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-net 0/4] Increase the limit of tuntap queues
Date: Tue, 18 Nov 2014 17:43:06 -0800
Message-ID: <CAADnVQKs6Y-47TuxFedT2Xi6OUAJqwGFKhip40cbVewmtw10wQ@mail.gmail.com>
References: <1416327778-17716-1-git-send-email-pagupta@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>, mst@redhat.com,
	dgibson@redhat.com, Veaceslav Falico <vfalico@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Vladislav Yasevich <vyasevic@redhat.com>,
	Jerry Chu <hkchu@google.com>,
	wuzhy@linux.vnet.ibm.com.pnq.redhat.com,
	Pavel Emelianov <xemul@parallels.com>,
	Tom Herbert <therbert@google.com>, bhutchings@solarflare.com,
	xii@google.com, Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	sergei.shtylyov@cogentembedded.com
To: Pankaj Gupta <pagupta@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416327778-17716-1-git-send-email-pagupta@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 18, 2014 at 8:22 AM, Pankaj Gupta <pagupta@redhat.com> wrote:
> Networking under KVM works best if we allocate a per-vCPU rx and tx
> queue in a virtual NIC. This requires a per-vCPU queue on the host side.
...
> I have done some testing to find out any regression and with sample program
>  which creates tun/tap for single queue / multiqueue device and it seems to be
>  working fine. I will also post the performance numbers.

Sounds quite exciting.
please share recommended setup (queue assignments) and
performance gains you're seeing.
