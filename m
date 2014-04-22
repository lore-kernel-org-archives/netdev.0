From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: Re: [PATCH 0/2] net: Add Keystone NetCP ethernet driver support
Date: Tue, 22 Apr 2014 19:56:19 -0400
Message-ID: <535701A3.5050309@ti.com>
References: <1398201675-17379-1-git-send-email-santosh.shilimkar@ti.com>
 <20140422150231.2e87b7eb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Sandeep Nair <sandeep_n@ti.com>,
 Rob Herring <robh+dt@kernel.org>, Grant Likely <grant.likely@linaro.org>,
 David Miller <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20140422150231.2e87b7eb@nehalam.linuxnetplumber.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Tuesday 22 April 2014 06:02 PM, Stephen Hemminger wrote:
> On Tue, 22 Apr 2014 17:21:13 -0400
> Santosh Shilimkar <santosh.shilimkar@ti.com> wrote:
> 
>> NetCP driver has a plug-in module architecture where each of the NetCP
>> sub-modules exist as a loadable kernel module which plug in to the netcp
>> core. These sub-modules are represented as "netcp-devices" in the dts
>> bindings. It is mandatory to have the ethernet switch sub-module for
>> the ethernet interface to be operational. Any other sub-module like the
>> PA is optional.
> 
> Where is the implementation of these modules. You need to include
> this as separate patch set. Also the hooks for these modules should all
> be EXPORT_SYMBOL_GPL() to disallow proprietary modules.
> 
There is no proprietary issue and all the hooks will be GPL. The plan is
to add them in another patch-set once the core driver gets merged. They need
some work to make them upstream ready.

Regards,
Santosh
