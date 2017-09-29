From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 4/8] net: dsa: use temporary dsa_device_ops
 variable
Date: Fri, 29 Sep 2017 12:11:58 -0700
Message-ID: <51f9c150-b882-55fb-a841-4cd33f55569c@gmail.com>
References: <20170929183635.8122-1-vivien.didelot@savoirfairelinux.com>
 <20170929183635.8122-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170929183635.8122-5-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/29/2017 11:36 AM, Vivien Didelot wrote:
> When resolving the DSA tagging protocol used by a CPU switch, use a
> temporary "tag_ops" variable to store the dsa_device_ops instead of
> using directly dst->tag_ops. This will make the future patches moving
> this pointer around easier to read.
> 
> There is no functional changes.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
