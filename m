From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH v4 3/3] net/xen-netback: Don't mix hexa
 and decimal with 0x in the printf format
Date: Wed, 17 Jun 2015 10:13:12 +0100
Message-ID: <558156480200007800085EAB@mail.emea.novell.com>
References: <1434481848-26387-1-git-send-email-julien.grall@citrix.com>
 <1434481848-26387-4-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ian Campbell" <ian.campbell@citrix.com>,
	"Wei Liu" <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Julien Grall" <julien.grall@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434481848-26387-4-git-send-email-julien.grall@citrix.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> On 16.06.15 at 21:10, <julien.grall@citrix.com> wrote:
> Append 0x to all %x in order to avoid while reading when there is other
> decimal value in the log.

To save on the space taken by the format strings you should prefer
%#x over 0x%x (like we do in the hypervisor).

Jan
