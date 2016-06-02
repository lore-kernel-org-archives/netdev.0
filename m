From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH -next 2/2] virtio_net: Read the advised MTU
Date: Thu, 2 Jun 2016 11:02:43 -0700
Message-ID: <575074C3.8040908@hpe.com>
References: <1464882211-18723-1-git-send-email-aconole@redhat.com>
	<1464882211-18723-3-git-send-email-aconole@redhat.com>
	<5750578E.4040406@hpe.com> <f7tmvn3sep3.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Aaron Conole <aconole@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <f7tmvn3sep3.fsf@redhat.com>
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

On 06/02/2016 10:06 AM, Aaron Conole wrote:
> Rick Jones <rick.jones2@hpe.com> writes:
>> One of the things I've been doing has been setting-up a cluster
>> (OpenStack) with JumboFrames, and then setting MTUs on instance vNICs
>> by hand to measure different MTU sizes.  It would be a shame if such a
>> thing were not possible in the future.  Keeping a warning if shrinking
>> the MTU would be good, leave the error (perhaps) to if an attempt is
>> made to go beyond the advised value.
>
> This was cut because it didn't make sense for such a warning to
> be issued, but it seems like perhaps you may want such a feature?  I
> agree with Michael, after thinking about it, that I don't know what sort
> of use the warning would serve.  After all, if you're changing the MTU,
> you must have wanted such a change to occur?

I don't need a warning, was simply willing to live with one when 
shrinking the MTU.  Didn't want an error.

happy benchmarking,

rick jones
