From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] devicetree: net: micrel-ksz90x1.txt: Properly explain
 skew settings
Date: Thu, 6 Oct 2016 04:04:26 -0700
Message-ID: <5c48a89f-3f2e-a74a-8e7b-a4b7397c2408@gmail.com>
References: <1475676188-10639-1-git-send-email-mike.looijmans@topic.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, robh+dt@kernel.org, mark.rutland@arm.com,
        andrew@lunn.ch
To: Mike Looijmans <mike.looijmans@topic.nl>,
        devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475676188-10639-1-git-send-email-mike.looijmans@topic.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/05/2016 07:03 AM, Mike Looijmans wrote:
> The KSZ9031 skew registers contain an offset, the chip's default value
> is "neutral" which does not add any skew. Programming a 0 into a skew
> property will actually set it the maximal negative adjustment and not
> to a neutral position as one would expect.
> 
> Explain this situation in the devicetree binding documentation and list
> the settings that the chip considers neutral.
> 
> Changing the implementation to accept negative values would have been
> a better solution, but would break existing configurations.
> 
> Signed-off-by: Mike Looijmans <mike.looijmans@topic.nl>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks!
-- 
Florian
