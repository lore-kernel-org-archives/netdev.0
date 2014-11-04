From: Xose Vazquez Perez <xose.vazquez@gmail.com>
Subject: Re: [PATCH v2 5/5] stmmac: pci: remove FSF address
Date: Tue, 04 Nov 2014 21:09:41 +0100
Message-ID: <54593285.3030201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	andriy.shevchenko@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:52156 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752816AbaKDUJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 15:09:45 -0500
Received: by mail-wi0-f177.google.com with SMTP id ex7so92762wid.16
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 12:09:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

> Andy Shevchenko wrote:
>> The FSF address is subject to change, thus remove it from the file.
>> 
>> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> 
> I cound 90t instances of this under drivers/net, therefore if this change is
          ^^^^^^^^^^^^^
> appropriate I'd rather someone script this and kill it across entire
> subdirectories.

It's a bit more, 555:

    134  * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
     96  * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
     89   51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
     86  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110,
     44  * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA or on the
     43   Boston, MA 02110-1301, USA.
     19  * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
     10   Temple Place - Suite 330, Boston, MA  02111-1307, USA.
      8  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
      5  * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
      5  * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
      5 # 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
      3  * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
      2 # 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA or on the
      1  *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
      1 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110,
      1 # Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
      1  * Boston, MA  02110-1301, USA.
      1  *  Boston, MA 02110-1301, USA.
      1  * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
