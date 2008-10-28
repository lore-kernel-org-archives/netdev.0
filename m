From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: [PATCH] phylib: add mdio-gpio bus driver (v3)
Date: Tue, 28 Oct 2008 13:31:35 +0200
Message-ID: <4906F817.4050306@teltonika.lt>
References: <20081028103537.28951.4804.stgit@Programuotojas.82-135-208-232.ip.zebra.lt> <8bd0f97a0810280350j385a0239if7a33928f7bb11f1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org
To: Mike Frysinger <vapier.adi@gmail.com>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <8bd0f97a0810280350j385a0239if7a33928f7bb11f1@mail.gmail.com>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mike Frysinger wrote:
> On Tue, Oct 28, 2008 at 06:35, Paulius Zaleckas wrote:
>> +config MDIO_GPIO
>> +       tristate "Support for GPIO bitbanged MDIO buses"
>>  config MDIO_OF_GPIO
>>        tristate "Support for GPIO lib-based bitbanged MDIO buses"
> 
> seems to me these drivers have the same description ...

Yes... but it is MDIO_OF_GPIO description that needs changing...
Should I make patch for it?

>> +++ b/include/linux/mdio-gpio.h
>> + * You should have received a copy of the GNU General Public License
>> + * along with this program; if not, write to the Free Software
>> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> 
> this is why short GPL notices are nice ... you dont end up with
> outdated contact information like this ...

It came from mdio-ofgpio driver... If you can mail suitable short GPL notice
I will put it there instead of updating address.

> -mike
