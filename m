From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Tue, 23 Sep 2014 08:19:22 +0100
Message-ID: <20140923071922.GA6944@casper.infradead.org>
References: <20140920081426.GE1821@nanopsycho.orion>
 <20140920105354.GA29419@casper.infradead.org>
 <CAADnVQK0wT2Fjqdg+C=ruSt8jF6sKeMo7cFj7K1fsu7-1u5g=g@mail.gmail.com>
 <20140922081341.GA20905@casper.infradead.org>
 <CA+mtBx-ZvkZ2ALGLsLEN7Cgn9gN_rY36ZhuqYC3mZ9WVxjFDaQ@mail.gmail.com>
 <20140922221727.GA4708@casper.infradead.org>
 <CA+mtBx9ZVQ5r5Hzy9-uEnk+iu+HKkOP4+VANC06Xf8VvTxktwQ@mail.gmail.com>
 <20140922225305.GB4708@casper.infradead.org>
 <CA+mtBx94TrLzQrZDo58d9ktma3ZioOpO=2FAODMRoiyiuYkQ9Q@mail.gmail.com>
 <5420CEAC.2070104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <therbert@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Vladislav Yasevich <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roop
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:58965 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752245AbaIWHTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 03:19:32 -0400
Content-Disposition: inline
In-Reply-To: <5420CEAC.2070104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/14 at 06:36pm, John Fastabend wrote:
> n-tuple has some deficiencies,
> 
> 	- its not possible to get the capabilities to learn what
> 	  fields are supported by the device, what actions, etc.
> 
> 	- its ioctl based so we have to poll the device
> 
> 	- only supports a single table, where we have devices with
> 	  multiple tables
> 
> 	- sort of the same as above but it doesn't allow creating new
> 	  tables or destroying old tables.

OK, I understand where Tom was going. Given we add feature detection
capabilities this could be used to identify the guest for fixed length
encap. I still assume HW won't be able to match on the inner header
for any variable lengh encap with metadata packet unless it can
actually parse the encap. I hope I didn't bring encap format to this
thread at this very moment ;-)
