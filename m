From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: ipsec impact on performance
Date: Tue, 1 Dec 2015 17:25:21 -0800
Message-ID: <565E4881.2030002@cumulusnetworks.com>
References: <20151201175953.GC21252@oracle.com> <565DE446.2070609@hpe.com>
 <565E41B8.1080206@cumulusnetworks.com> <20151202010926.GH23178@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20151202010926.GH23178@oracle.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/1/15 5:09 PM, Sowmini Varadhan wrote:
> The not-so-great news is that I see that just adding perf tracepoints
> (not even enabling them!) seems to make a small diff (3 Gbps vs 3.2 Gbps)
> to my numbers. Is that mere standard-deviation, or something
> one should be aware of, about perf?

existence of traepoints has no overhead until activated (ie., launch 
perf or start ftrace for those tracepoints).
