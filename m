From: Pau Koning <paukoning-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/7] batman-adv: Move soft-interface
 initialization to ndo_init
Date: Mon, 24 Dec 2012 16:36:03 +0100
Message-ID: <CANiGF98L_Ca20Eb+qVuX1126rWoeqQzOASshB7c2LQ-Fi7DiXA@mail.gmail.com>
References: <1353715332-4284-1-git-send-email-sven@narfation.org>
 <CANiGF9_=svx+W4Rhx8BL1NBv0H1aULeh71sX9YkMeR66OmmimA@mail.gmail.com>
 <201212242237.07208.lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
To: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <201212242237.07208.lindner_marek-LWAfsSFWpa4@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Mon, Dec 24, 2012 at 3:37 PM, Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org> wrote:
> On Monday, December 24, 2012 22:22:44 Pau Koning wrote:
>> On Sat, Nov 24, 2012 at 1:02 AM, Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org> wrote:
>> > The initialization of an net_device object should be done in the
>> > init/constructor function and not from the outside after the
>> > register_netdevice was done to avoid race conditions.
>>
>> This patchset seems to be similar. Shouldn't it have been part of
>> 3.8-rc1 or got rejected? Neither of it happened in the last month
>
> It was discussed and a decision was made. Please read all mails in this thread
> before making noise.

What decision? I only see something about Patch 6 and Patch 7: Antonio
Quartulli doesn't want rtnetlink support in batman-adv. I don't see
any other statement about the rest of the patchset.
