From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V4 0/3] basic busy polling support for vhost_net
Date: Tue, 15 Mar 2016 11:10:44 +0800
Message-ID: <56E77D34.3050104@redhat.com>
References: <1457090693-55974-1-git-send-email-jasowang@redhat.com>
	<20160309202645.030ad7b2@bahia.lab.toulouse-stg.fr.ibm.com>
	<201603100648.u2A6mSTl020833@d06av07.portsmouth.uk.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yang.zhang.wz@gmail.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, borntraeger@de.ibm.com
To: Michael Rapoport <RAPOPORT@il.ibm.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <201603100648.u2A6mSTl020833@d06av07.portsmouth.uk.ibm.com>
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



On 03/10/2016 02:48 PM, Michael Rapoport wrote:
> Hi Greg,
>
>> > Greg Kurz <gkurz@linux.vnet.ibm.com> wrote on 03/09/2016 09:26:45 PM:
>>> > > On Fri,  4 Mar 2016 06:24:50 -0500
>>> > > Jason Wang <jasowang@redhat.com> wrote:
>> > 
>>> > > This series tries to add basic busy polling for vhost net. The idea is
>>> > > simple: at the end of tx/rx processing, busy polling for new tx added
>>> > > descriptor and rx receive socket for a while. The maximum number of
>>> > > time (in us) could be spent on busy polling was specified ioctl.
>>> > > 
>>> > > Test A were done through:
>>> > > 
>>> > > - 50 us as busy loop timeout
>>> > > - Netperf 2.6
>>> > > - Two machines with back to back connected mlx4
>> > 
>> > Hi Jason,
>> > 
>> > Could this also improve performance if both VMs are
>> > on the same host system ?
> I've experimented a little with Jason's patches and guest-to-guest netperf 
> when both guests were on the same host, and I saw improvements for that 
> case.
>  

Good to know this, I haven't tested this before but from the codes, it
should work for VM2VM case too.

Thanks a lot for the testing.
