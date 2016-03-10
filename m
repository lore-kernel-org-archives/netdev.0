From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH nf-next v10 7/8] openvswitch: Delay conntrack helper call for new connections.
Date: Thu, 10 Mar 2016 14:15:03 -0800
Message-ID: <EBD25405-3777-49CA-A8F7-5B1A93E772EB@ovn.org>
References: <1457636063-92746-1-git-send-email-jarno@ovn.org> <1457636063-92746-8-git-send-email-jarno@ovn.org> <CAPWQB7Hshep+Uy482hiX5UYF67Zd4OXVCgUsC08TA_78JghoZg@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAPWQB7Hshep+Uy482hiX5UYF67Zd4OXVCgUsC08TA_78JghoZg@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for the reviews, Joe!

Now we have acks for the patches 3-8, but not for 1 and 2 that touch netfilter proper. Who could review those?

  Jarno

> On Mar 10, 2016, at 2:01 PM, Joe Stringer <joe@ovn.org> wrote:
> 
> On 11 March 2016 at 07:54, Jarno Rajahalme <jarno@ovn.org> wrote:
>> There is no need to help connections that are not confirmed, so we can
>> delay helping new connections to the time when they are confirmed.
>> This change is needed for NAT support, and having this as a separate
>> patch will make the following NAT patch a bit easier to review.
>> 
>> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> 
> Acked-by: Joe Stringer <joe@ovn.org>

