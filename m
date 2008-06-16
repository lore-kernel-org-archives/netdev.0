From: Patrick McHardy <kaber@trash.net>
Subject: Re: unlock iptables in netns
Date: Mon, 16 Jun 2008 13:21:08 +0200
Message-ID: <48564CA4.6050005@trash.net>
References: <200806102127.21093.adobriyan@parallels.com> <484F7663.1080408@trash.net> <48563FBB.4080303@trash.net> <20080616110434.GA5103@martell.zuzino.mipt.ru> <48564B70.2020400@trash.net> <48564BD0.3010006@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	devel@openvz.org, den@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <48564BD0.3010006@openvz.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov wrote:
> Patrick McHardy wrote:
>> Alexey Dobriyan wrote:
>>> On Mon, Jun 16, 2008 at 12:26:03PM +0200, Patrick McHardy wrote:
>>>> By the way, is there already work done for conntrack/NAT namespace
>>>> support? I have this patch that uses marks for something very similar
>>>> that should be easy to adjust.
>>> Yes, right now I'm fighting something which looks like double free
>>> of conntrack during clone(CLONE_NEWNET)/exit test despite none created
>>> in netns. And unknown to me dimensions of input and output packet codepaths.
>>> :^)
>>>
>>> Preliminaty details:
>>> 	struct nf_conn::ct_net which pins netns
>>  From the VLAN code, I thought namespaces could also be identified
>> numerically. That would reduce the size increase of struct nf_conn.
> 
> Numerically? I made VLAN-s netnsization, but everything was spinning
> around the struct net *pointer*. Can you elaborate on this?

I think I just misunderstood the meaning of vlan_net_id.
