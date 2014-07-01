From: Kay Sievers <kay@vrfy.org>
Subject: Re: [PATCH] Use dev_port for the ID of a network
	device.
Date: Tue, 1 Jul 2014 02:33:19 +0200
Message-ID: <CAPXgP13o=qZc0q+Af0sd6bLKUawKYw0L_SLqh3VgLZBJ1CfYSA@mail.gmail.com>
References: <1404160596-25859-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, systemd-devel@lists.freedesktop.org
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Return-path: <systemd-devel-bounces@lists.freedesktop.org>
In-Reply-To: <1404160596-25859-1-git-send-email-cascardo@linux.vnet.ibm.com>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/systemd-devel>,
 <mailto:systemd-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/systemd-devel>
List-Post: <mailto:systemd-devel@lists.freedesktop.org>
List-Help: <mailto:systemd-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/systemd-devel>,
 <mailto:systemd-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: systemd-devel-bounces@lists.freedesktop.org
Sender: "systemd-devel" <systemd-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

On Mon, Jun 30, 2014 at 10:36 PM, Thadeu Lima de Souza Cascardo
<cascardo@linux.vnet.ibm.com> wrote:
> For network devices on the same PCI function, dev_id should not be used,
> since its purpose is for IPv6 support on interfaces with the same MAC
> address.
>
> The new dev_port sysfs attribute should be used when it is found. When
> it is not, using dev_id might work.

I don't see a problem switching this over, but why would we keep using
dev_id if it is not the right thing to use?

Kay
