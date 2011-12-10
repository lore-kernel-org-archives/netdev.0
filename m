From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 REPOST] xen-netfront: delay gARP until backend
	switches to Connected
Date: Fri, 09 Dec 2011 19:24:39 -0500 (EST)
Message-ID: <20111209.192439.275865894437319638.davem@davemloft.net>
References: <1323430738-3798-1-git-send-email-lersek@redhat.com>
	<20111209.134514.2071890208094978847.davem@davemloft.net>
	<1323465781.20936.49.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jeremy@goop.org, xen-devel@lists.xensource.com, konrad.wilk@oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, lersek@redhat.com
To: Ian.Campbell@citrix.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1323465781.20936.49.camel@dagon.hellion.org.uk>
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

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Fri, 9 Dec 2011 21:23:00 +0000

> On Fri, 2011-12-09 at 18:45 +0000, David Miller wrote:
>> From: Laszlo Ersek <lersek@redhat.com>
>> Date: Fri,  9 Dec 2011 12:38:58 +0100
>> 
>> > These two together provide complete ordering. Sub-condition (1) is
>> > satisfied by pvops commit 43223efd9bfd.
>> 
>> I don't see this commit in Linus's tree,
> 
> The referenced commit is in
> git://git.kernel.org/pub/scm/linux/kernel/git/jeremy/xen.git#xen/next-2.6.32  some people call the "pvops tree" but there's no reason to expect someone outside the Xen world to know that...
> 
> A better reference would have been 6b0b80ca7165 in
> git://xenbits.xen.org/people/ianc/linux-2.6.git#upstream/dom0/backend/netback-history which is the precise branch that was flattened to make f942dc2552b8, which is the upstream commit that added netback, so this change is already in upstream.

I want the commit message fixed so someone seeing the commit ID can
figure out what it actually refers to.
