From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC 07/20] net: dsa: list ports in switch\\
Date: Thu, 28 Apr 2016 10:00:43 -0700
Message-ID: <572241BB.1070304@gmail.com>
References: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1461796217-18893-8-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20160427231537.GJ29024@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>
To: Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160427231537.GJ29024@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27/04/16 16:15, Andrew Lunn wrote:
> On Wed, Apr 27, 2016 at 06:30:04PM -0400, Vivien Didelot wrote:
>> List DSA port structures in their switch structure, so that drivers can
>> iterate on them to retrieve information such as their ports membership.
> 
> And this would be so much easier using a plan array.

Agreed, I do not see much value in doing this at the moment. Even if you
have unused ports in a switch, allocating an array is a small price to
pay compared to directly indexing by port number.

NAK from me unless there is a compelling reason for doing so.
-- 
Florian
