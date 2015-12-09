From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v4 4/8] openvswitch: Update the CT state key only
 after nf_conntrack_in().
Date: Wed, 9 Dec 2015 16:40:46 +0300
Message-ID: <56682F5E.2090006@cogentembedded.com>
References: <1449622870-48944-1-git-send-email-jarno@ovn.org>
 <1449622870-48944-5-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, dev@openvswitch.org
To: Jarno Rajahalme <jarno@ovn.org>, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1449622870-48944-5-git-send-email-jarno@ovn.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/9/2015 4:01 AM, Jarno Rajahalme wrote:

> Only a successful nf_conntrack_in() call can effect a connection state
> change, so if suffices to update the key only after the
> nf_conntrack_in() returns.
>
> This change is needed for the later NAT patches.
>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> ---
>   net/openvswitch/conntrack.c | 9 ++++++---
>   1 file changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> index a28a819..10f4a6e 100644
> --- a/net/openvswitch/conntrack.c
> +++ b/net/openvswitch/conntrack.c
> @@ -194,7 +194,6 @@ static int ovs_ct_set_mark(struct sk_buff *skb, struct sw_flow_key *key,
>   	struct nf_conn *ct;
>   	u32 new_mark;
>
> -

    Unrelated whitespace change?

[...]

MBR, Sergei

