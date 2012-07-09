From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [net-next RFC V5 0/5] Multiqueue virtio-net
Date: Mon, 09 Jul 2012 09:46:47 -0700
Message-ID: <4FFB0AF7.1080604@hp.com>
References: <1341484194-8108-1-git-send-email-jasowang@redhat.com>
	<4FF5D2B7.6080602@hp.com> <4FF696C9.5070907@redhat.com>
	<4FF710FD.2090100@hp.com> <4FFA4EAD.7000707@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, habanero@linux.vnet.ibm.com, mashirle@us.ibm.com,
	kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	tahm@linux.vnet.ibm.com, jwhan@filewood.snu.ac.kr,
	davem@davemloft.net, sri@us.ibm.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <4FFA4EAD.7000707@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 07/08/2012 08:23 PM, Jason Wang wrote:
> On 07/07/2012 12:23 AM, Rick Jones wrote:
>> On 07/06/2012 12:42 AM, Jason Wang wrote:
>> Which mechanism to address skew error?  The netperf manual describes
>> more than one:
>
> This mechanism is missed in my test, I would add them to my test scripts.
>>
>> http://www.netperf.org/svn/netperf2/trunk/doc/netperf.html#Using-Netperf-to-Measure-Aggregate-Performance
>>
>>
>> Personally, my preference these days is to use the "demo mode" method
>> of aggregate results as it can be rather faster than (ab)using the
>> confidence intervals mechanism, which I suspect may not really scale
>> all that well to large numbers of concurrent netperfs.
>
> During my test, the confidence interval would even hard to achieved in
> RR test when I pin vhost/vcpus in the processors, so I didn't use it.

When running aggregate netperfs, *something* has to be done to address 
the prospect of skew error.  Otherwise the results are suspect.

happy benchmarking,

rick jones
