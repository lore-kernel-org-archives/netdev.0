From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: linux-next network throughput performance regression
Date: Fri, 6 Nov 2015 13:45:52 -0700
Message-ID: <563D1180.60206@cumulusnetworks.com>
References: <CY1PR03MB13760C9F1AABC4EBC455B85CC4280@CY1PR03MB1376.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: Simon Xiao <sixiao@microsoft.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CY1PR03MB13760C9F1AABC4EBC455B85CC4280@CY1PR03MB1376.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/6/15 1:31 PM, Simon Xiao wrote:
> I compared the network throughput performance on SLES12 bare metal servers, between SLES12 default kernel and latest linux-next (2015-11-05) kernel, based on the test results, I suspect there is a network regression exists on Linux-Next over the 40G Ethernet network:
> a) iperf3 reports 50% performance drop with single TCP stream on latest linux-next;
> b) iperf3 reports 10% ~ 30% performance drop with 2 to 128 TCP streams on latest linux-next;
> Another throughput benchmarking tool (ntttcp-for-linux) test result is also listed at the end of the email for reference.
>

Can you post your kernel config file?
