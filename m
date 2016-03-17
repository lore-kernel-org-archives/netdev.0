From: Aaron Conole <aconole@redhat.com>
Subject: Re: [RFC v2 -next 0/2] virtio-net: Advised MTU feature
Date: Thu, 17 Mar 2016 17:24:05 -0400
Message-ID: <f7t37rox0ga.fsf@redhat.com>
References: <1458075853-14789-1-git-send-email-aconole@redhat.com>
	<56E87FEC.2030600@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <56E87FEC.2030600@hpe.com> (Rick Jones's message of "Tue, 15 Mar
	2016 14:34:36 -0700")
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

Rick Jones <rick.jones2@hpe.com> writes:

> On 03/15/2016 02:04 PM, Aaron Conole wrote:
>> The following series adds the ability for a hypervisor to set an MTU on the
>> guest during feature negotiation phase. This is useful for VM orchestration
>> when, for instance, tunneling is involved and the MTU of the various systems
>> should be homogenous.
>>
>> The first patch adds the feature bit as described in the proposed VFIO spec
>> addition found at
>> https://lists.oasis-open.org/archives/virtio-dev/201603/msg00001.html
>>
>> The second patch adds a user of the bit, and a warning when the guest changes
>> the MTU from the hypervisor advised MTU. Future patches may add more thorough
>> error handling.
>
> How do you see this interacting with VMs getting MTU settings via DHCP?

This is intended for networks where the VMs are not given MTU via
DHCP. I don't think it should negatively interfere with such a
network. Does that make sense?

-Aaron

> rick jones
>
>>
>> v2:
>> * Whitespace and code style cleanups from Sergei Shtylyov and Paolo Abeni
>> * Additional test before printing a warning
>>
>> Aaron Conole (2):
>>    virtio: Start feature MTU support
>>    virtio_net: Read the advised MTU
>>
>>   drivers/net/virtio_net.c        | 12 ++++++++++++
>>   include/uapi/linux/virtio_net.h |  3 +++
>>   2 files changed, 15 insertions(+)
>>
