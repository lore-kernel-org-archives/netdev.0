From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH resend] can: c_can: Fix tx_bytes accounting
Date: Thu, 24 Mar 2011 12:49:03 +0100
Message-ID: <4D8B2FAF.5040000@grandegger.com>
References: <16a340801622a96218c76dbbabc7a23f.squirrel@www.linutronix.de>	<D5ECB3C7A6F99444980976A8C6D896384DF0D6F721@EAPEX1MAIL1.st.com>	<1300963120.3295.7.camel@localhost>	<4D8B1641.6000706@grandegger.com>	<1300966010.3295.40.camel@localhost>
	<20110324104925.GB339@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Altenberg <jan-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Bhupesh SHARMA <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>,
	"b.spranger-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org" <b.spranger-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110324104925.GB339-MxZ6Iy/zr/UdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/24/2011 11:49 AM, Kurt Van Dijck wrote:
> On Thu, Mar 24, 2011 at 12:26:50PM +0100, Jan Altenberg wrote:
>> The current SocketCAN implementation for the Bosch c_can cell doesn't
>> account the TX bytes correctly, because it calls
>> c_can_inval_msg_object() (which clears the msg ctrl register) before
>> reading the DLC value:
>>
>> The fix is quite easy: Just move c_can_inval_msg_object() to the end of
>> the if() statement. So:
>>       * We only call c_can_inval_msg_object() if the message was
>>         actually transmitted
>>       * We read out the DLC value _before_ clearing the msg ctrl
>>         register
>>
>> Signed-off-by: Jan Altenberg <jan-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
> Acked-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
